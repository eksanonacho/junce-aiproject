import {
  Controller,
  Get,
  Post,
  Delete,
  Param,
  Query,
  UseInterceptors,
  UploadedFile,
  Body,
  BadRequestException,
  Res,
  StreamableFile,
  UseGuards,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { DocumentService } from './document.service';
import type { Response } from 'express';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import * as path from 'path';
import * as fs from 'fs';

@Controller()
export class DocumentController {
  constructor(private readonly documentService: DocumentService) {}

  // --- Public: document requirements template (no submission context) ---
  @Get('/api/document-requirements')
  async getRequirementsTemplate(@Query('mode') mode: string) {
    if (!mode || !['QUICK', 'STANDARD', 'DEEP'].includes(mode.toUpperCase())) {
      throw new BadRequestException('Invalid or missing mode parameter');
    }
    return this.documentService.getRequirementsTemplate(mode.toUpperCase());
  }

  // --- V2: document checklist with submission context (requires X-Submission-Token) ---
  @Get('/api/submissions/:submissionPublicId/document-checklist')
  async getChecklist(
    @Param('submissionPublicId') submissionPublicId: string,
  ) {
    return this.documentService.getChecklist(submissionPublicId);
  }

  // --- V2: upload document (requires X-Submission-Token) ---
  @Post('/api/submissions/:submissionPublicId/documents')
  @UseInterceptors(FileInterceptor('file', {
    limits: { fileSize: 20 * 1024 * 1024 }, // 20MB
    fileFilter: (_req, file, cb) => {
      const allowedMimes = [
        'application/pdf',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        'application/vnd.ms-excel',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'application/msword',
        'image/jpeg',
        'image/png',
      ];
      if (allowedMimes.includes(file.mimetype)) {
        cb(null, true);
      } else {
        cb(new BadRequestException(`不支持的文件类型: ${file.mimetype}`), false);
      }
    },
  }))
  async uploadDocument(
    @Param('submissionPublicId') submissionPublicId: string,
    @UploadedFile() file: any,
    @Body('docType') docType: string,
  ) {
    if (!file) throw new BadRequestException('文件不能为空');
    if (!docType) throw new BadRequestException('docType 不能为空');
    return this.documentService.uploadDocument(submissionPublicId, file, docType);
  }

  // --- V2: list documents (requires X-Submission-Token) ---
  @Get('/api/submissions/:submissionPublicId/documents')
  async listDocuments(@Param('submissionPublicId') submissionPublicId: string) {
    return this.documentService.listDocuments(submissionPublicId);
  }

  // --- V2: delete document (requires X-Submission-Token) ---
  @Delete('/api/submissions/:submissionPublicId/documents/:documentPublicId')
  async deleteDocument(
    @Param('submissionPublicId') submissionPublicId: string,
    @Param('documentPublicId') documentPublicId: string,
  ) {
    return this.documentService.deleteDocument(submissionPublicId, documentPublicId);
  }

  // --- Admin: list documents for a submission ---
  @UseGuards(JwtAuthGuard)
  @Get('/api/admin/submissions/:submissionPublicId/documents')
  async adminListDocuments(@Param('submissionPublicId') submissionPublicId: string) {
    return this.documentService.listDocuments(submissionPublicId);
  }

  // --- Admin: download a document ---
  @UseGuards(JwtAuthGuard)
  @Get('/api/admin/documents/:documentPublicId/download')
  async downloadDocument(
    @Param('documentPublicId') documentPublicId: string,
    @Res({ passthrough: false }) res: Response,
  ) {
    const doc = await this.documentService.getDocumentForDownload(documentPublicId);
    const filePath = path.resolve(doc.storagePath);
    // Path traversal protection
    const uploadsDir = path.resolve('uploads');
    if (!filePath.startsWith(uploadsDir) || filePath.includes('..')) {
      throw new BadRequestException('Invalid file path');
    }
    if (!fs.existsSync(filePath)) {
      throw new BadRequestException('文件不存在');
    }
    res.set({
      'Content-Type': doc.mimeType,
      'Content-Disposition': `attachment; filename*=UTF-8''${encodeURIComponent(doc.originalName)}`,
      'Content-Length': doc.sizeBytes,
    });
    const stream = fs.createReadStream(filePath);
    return new StreamableFile(stream);
  }
}
