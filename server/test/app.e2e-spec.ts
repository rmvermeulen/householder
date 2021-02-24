import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';
import { userMatcher } from '../src/testing/data.matchers';

describe('AppController (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  afterAll(() => app.close());

  it('/ (GET)', () => {
    return request(app.getHttpServer())
      .get('/')
      .expect(200)
      .expect('Hello World!');
  });

  describe('users', () => {
    it('/users (GET)', () =>
      request(app.getHttpServer())
        .get('/users')
        .expect(200)
        .expect(({ body }) => {
          expect(body).toBeInstanceOf(Array);
          for (const item of body) {
            expect(item).toStrictEqual(userMatcher);
          }
        }));
    it('/users/:id (GET)', () =>
      request(app.getHttpServer())
        .get('/users')
        .expect(200)
        .expect(userMatcher));
  });
});
