import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getHello(): any {
    const o = {
      data: true,
      value: 123,
      fields: ['connection', 'app.controller'],
    };
    return [o, o, o, o];
  }
}
