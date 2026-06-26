import { Injectable, BadRequestException, NotFoundException, UnauthorizedException, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import * as fs from 'fs';
import * as path from 'path';
import * as crypto from 'crypto';
import * as bcrypt from 'bcryptjs';

@Injectable()
export class DocumentService {
  private readonly logger = new Logger(DocumentService.name);

  constructor(private readonly prisma: PrismaService) {
    // Ensure uploads directory exists
    const uploadsDir = path.resolve('uploads');
    if (!fs.existsSync(uploadsDir)) {
      fs.mkdirSync(uploadsDir, { recursive: true });
    }
  }

  /** Sanitize filename: remove path separators and dangerous chars, keep Chinese + alphanumeric + dots + dashes */
  private sanitizeFilename(name: string): string {
    return name.replace(/[^a-zA-Z0-9一-龥._-]/g, '_').substring(0, 200);
  }

  /** Validate MIME type against extension */
  private validateFileType(mimeType: string, originalName: string): void {
    const ext = path.extname(originalName).toLowerCase();
    const allowedPairs: Record<string, string[]> = {
      'application/pdf': ['.pdf'],
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': ['.xlsx'],
      'application/vnd.ms-excel': ['.xls'],
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document': ['.docx'],
      'application/msword': ['.doc'],
      'image/jpeg': ['.jpg', '.jpeg'],
      'image/png': ['.png'],
    };
    const allowedExts = allowedPairs[mimeType];
    if (!allowedExts || !allowedExts.includes(ext)) {
      throw new BadRequestException(`文件类型和扩展名不匹配: ${mimeType} / ${ext}`);
    }
  }

  /** Validate file content via magic bytes */
  private validateMagicBytes(buffer: Buffer, mimeType: string): void {
    if (buffer.length < 4) throw new BadRequestException('文件内容过短，无法校验');
    const h = buffer;
    // PDF: %PDF
    if (mimeType === 'application/pdf') { if (h[0]!==0x25||h[1]!==0x50||h[2]!==0x44||h[3]!==0x46) throw new BadRequestException('文件内容不是有效的 PDF 格式'); return; }
    // PNG: 89 50 4E 47
    if (mimeType === 'image/png') { if (h[0]!==0x89||h[1]!==0x50||h[2]!==0x4E||h[3]!==0x47) throw new BadRequestException('文件内容不是有效的 PNG 格式'); return; }
    // JPEG: FF D8 FF
    if (mimeType === 'image/jpeg') { if (h[0]!==0xFF||h[1]!==0xD8||h[2]!==0xFF) throw new BadRequestException('文件内容不是有效的 JPEG 格式'); return; }
    // Office Open XML (xlsx/docx): PK
    if (mimeType.startsWith('application/vnd.openxmlformats-officedocument')) { if (h[0]!==0x50||h[1]!==0x4B) throw new BadRequestException('文件内容不是有效的 Office 文档格式'); return; }
    // Legacy DOC/XLS: D0 CF 11 E0
    if (mimeType==='application/msword'||mimeType==='application/vnd.ms-excel') { if (h[0]!==0xD0||h[1]!==0xCF||h[2]!==0x11||h[3]!==0xE0) throw new BadRequestException('文件内容不是有效的 MS Office 文档格式'); return; }
  }

  /** Pure template — no submission context, no uploaded status */
  async getRequirementsTemplate(mode: string) {
    const requirements = await this.prisma.documentRequirement.findMany({
      where: { isActive: true },
      orderBy: { sortOrder: 'asc' },
    });

    const requiredField = mode === 'QUICK' ? 'requiredForQuick'
      : mode === 'STANDARD' ? 'requiredForStandard'
      : 'requiredForDeep';

    return requirements.map((r) => ({
      code: r.code,
      name: r.name,
      category: r.category,
      description: r.description,
      required: (r as any)[requiredField] === true,
      affectsDimensions: r.affectsDimensions || [],
    }));
  }

  /** Full checklist with uploaded status + completeness scoring */
  async getChecklist(submissionPublicId: string) {
    const submission = await this.prisma.submission.findUnique({
      where: { publicId: submissionPublicId },
      include: { uploadedDocuments: true },
    });
    if (!submission) throw new NotFoundException('提交记录不存在');
    if (!submission.mode) throw new BadRequestException('该提交非 V2 初诊');

    const mode = submission.mode;
    const requirements = await this.prisma.documentRequirement.findMany({
      where: { isActive: true },
      orderBy: { sortOrder: 'asc' },
    });

    const requiredField = mode === 'QUICK' ? 'requiredForQuick'
      : mode === 'STANDARD' ? 'requiredForStandard'
      : 'requiredForDeep';

    const uploadedMap = new Map(
      submission.uploadedDocuments.map((d) => [d.docType, d]),
    );

    // Build requirements list with uploaded status
    const reqList = requirements.map((r) => {
      const isRequired = (r as any)[requiredField] === true;
      const uploaded = uploadedMap.get(r.code);
      return {
        code: r.code,
        name: r.name,
        category: r.category,
        description: r.description,
        required: isRequired,
        affectsDimensions: r.affectsDimensions || [],
        uploaded: !!uploaded,
        uploadedDocument: uploaded ? {
          publicId: uploaded.publicId,
          originalName: uploaded.originalName,
          mimeType: uploaded.mimeType,
          sizeBytes: uploaded.sizeBytes,
          createdAt: uploaded.createdAt,
        } : null,
      };
    });

    // Calculate completeness
    const requiredReqs = reqList.filter((r) => r.required);
    const optionalReqs = reqList.filter((r) => !r.required);
    const uploadedRequired = requiredReqs.filter((r) => r.uploaded).length;
    const uploadedOptional = optionalReqs.filter((r) => r.uploaded).length;

    const requiredScore = requiredReqs.length > 0
      ? (uploadedRequired / requiredReqs.length) * 70 : 70;
    const optionalScore = optionalReqs.length > 0
      ? (uploadedOptional / optionalReqs.length) * 30 : 30;
    const completenessScore = Math.round(requiredScore + optionalScore);

    // Dimension confidence
    const dimensions = ['PROFIT', 'RISK', 'CASH_FLOW', 'EFFICIENCY'];
    const dimensionConfidence: Record<string, number> = {};
    for (const dim of dimensions) {
      const dimReqs = reqList.filter((r) =>
        (r.affectsDimensions as string[])?.includes(dim),
      );
      if (dimReqs.length === 0) {
        dimensionConfidence[dim] = 100;
      } else {
        const uploaded = dimReqs.filter((r) => r.uploaded).length;
        dimensionConfidence[dim] = Math.round((uploaded / dimReqs.length) * 100);
      }
    }

    const missingDocuments = requiredReqs
      .filter((r) => !r.uploaded)
      .map((r) => r.name);

    return {
      mode,
      completenessScore,
      uploadedCount: submission.uploadedDocuments.length,
      requiredCount: requiredReqs.length,
      missingDocuments,
      dimensionConfidence,
      requirements: reqList,
    };
  }

  async uploadDocument(
    submissionPublicId: string,
    file: any,
    docType: string,
  ) {
    const submission = await this.prisma.submission.findUnique({
      where: { publicId: submissionPublicId },
    });
    if (!submission) throw new NotFoundException('提交记录不存在');

    // Validate docType exists
    const requirement = await this.prisma.documentRequirement.findUnique({
      where: { code: docType },
    });
    if (!requirement) throw new BadRequestException(`未知的资料类型: ${docType}`);

    // Validate file
    this.validateFileType(file.mimetype, file.originalname);
    this.validateMagicBytes(file.buffer, file.mimetype);

    // Create submission directory
    const submissionDir = path.resolve('uploads', submissionPublicId);
    if (!fs.existsSync(submissionDir)) {
      fs.mkdirSync(submissionDir, { recursive: true });
    }

    // Create document record first to get publicId
    const sanitized = this.sanitizeFilename(file.originalname);

    // Check if already uploaded for this docType — replace if exists
    const existing = await this.prisma.uploadedDocument.findFirst({
      where: { submissionId: submission.id, docType },
    });
    if (existing) {
      // Delete old file
      const oldPath = path.resolve(existing.storagePath);
      if (fs.existsSync(oldPath) && oldPath.startsWith(path.resolve('uploads'))) {
        fs.unlinkSync(oldPath);
      }
      // Delete old record
      await this.prisma.uploadedDocument.delete({ where: { id: existing.id } });
    }

    // Create record
    const doc = await this.prisma.uploadedDocument.create({
      data: {
        submissionId: submission.id,
        docType,
        originalName: sanitized,
        mimeType: file.mimetype,
        sizeBytes: file.size,
        storagePath: `uploads/${submissionPublicId}/TEMP`, // will update after getting publicId
        uploadStatus: 'UPLOADING',
      },
    });

    // Now write file with correct path
    const ext = path.extname(sanitized);
    const filename = `${doc.publicId}${ext}`;
    const storagePath = `uploads/${submissionPublicId}/${filename}`;
    const fullPath = path.resolve(storagePath);

    // Path traversal protection
    if (!fullPath.startsWith(path.resolve('uploads')) || fullPath.includes('..')) {
      await this.prisma.uploadedDocument.delete({ where: { id: doc.id } });
      throw new BadRequestException('Invalid file path');
    }

    fs.writeFileSync(fullPath, file.buffer);

    // Update record with correct storagePath
    const updated = await this.prisma.uploadedDocument.update({
      where: { id: doc.id },
      data: { storagePath, uploadStatus: 'UPLOADED' },
    });

    this.logger.log(`File uploaded: ${storagePath} (${file.size} bytes)`);

    return {
      publicId: updated.publicId,
      docType: updated.docType,
      originalName: updated.originalName,
      mimeType: updated.mimeType,
      sizeBytes: updated.sizeBytes,
      uploadStatus: updated.uploadStatus,
      createdAt: updated.createdAt,
    };
  }

  async listDocuments(submissionPublicId: string) {
    const submission = await this.prisma.submission.findUnique({
      where: { publicId: submissionPublicId },
      include: { uploadedDocuments: { orderBy: { createdAt: 'desc' } } },
    });
    if (!submission) throw new NotFoundException('提交记录不存在');

    return submission.uploadedDocuments.map((d) => ({
      publicId: d.publicId,
      docType: d.docType,
      originalName: d.originalName,
      mimeType: d.mimeType,
      sizeBytes: d.sizeBytes,
      uploadStatus: d.uploadStatus,
      createdAt: d.createdAt,
    }));
  }

  async deleteDocument(submissionPublicId: string, documentPublicId: string) {
    const submission = await this.prisma.submission.findUnique({
      where: { publicId: submissionPublicId },
    });
    if (!submission) throw new NotFoundException('提交记录不存在');

    const doc = await this.prisma.uploadedDocument.findFirst({
      where: { publicId: documentPublicId, submissionId: submission.id },
    });
    if (!doc) throw new NotFoundException('文件记录不存在');

    // Delete physical file
    const filePath = path.resolve(doc.storagePath);
    const uploadsDir = path.resolve('uploads');
    if (filePath.startsWith(uploadsDir) && !filePath.includes('..') && fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
    }

    await this.prisma.uploadedDocument.delete({ where: { id: doc.id } });
    return { success: true };
  }

  async getDocumentForDownload(documentPublicId: string) {
    const doc = await this.prisma.uploadedDocument.findUnique({
      where: { publicId: documentPublicId },
    });
    if (!doc) throw new NotFoundException('文件记录不存在');
    return {
      storagePath: doc.storagePath,
      originalName: doc.originalName,
      mimeType: doc.mimeType,
      sizeBytes: doc.sizeBytes,
    };
  }

  /** Validate submission access token */
  async validateSubmissionToken(submissionPublicId: string, token?: string): Promise<void> {
    if (!token) throw new UnauthorizedException({ code: 'TOKEN_REQUIRED', message: '缺少访问凭证' });
    const submission = await this.prisma.submission.findUnique({ where: { publicId: submissionPublicId } });
    if (!submission || !submission.accessTokenHash) {
      throw new UnauthorizedException({ code: 'INVALID_TOKEN', message: '访问凭证无效' });
    }
    const valid = await bcrypt.compare(token, submission.accessTokenHash);
    if (!valid) throw new UnauthorizedException({ code: 'INVALID_TOKEN', message: '访问凭证无效' });
  }

  /** Compute completeness score and update submission */
  async computeAndSaveCompleteness(submissionPublicId: string): Promise<{
    score: number;
    detail: any;
  }> {
    const checklist = await this.getChecklist(submissionPublicId);
    await this.prisma.submission.update({
      where: { publicId: submissionPublicId },
      data: {
        documentCompletenessScore: checklist.completenessScore,
        documentCompletenessDetail: {
          mode: checklist.mode,
          uploadedCount: checklist.uploadedCount,
          requiredCount: checklist.requiredCount,
          missingDocuments: checklist.missingDocuments,
          dimensionConfidence: checklist.dimensionConfidence,
        },
      },
    });
    return {
      score: checklist.completenessScore,
      detail: {
        mode: checklist.mode,
        uploadedCount: checklist.uploadedCount,
        requiredCount: checklist.requiredCount,
        missingDocuments: checklist.missingDocuments,
        dimensionConfidence: checklist.dimensionConfidence,
      },
    };
  }
}
