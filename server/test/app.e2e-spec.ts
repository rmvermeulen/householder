import { INestApplication } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';
import { userMatcher } from '../src/testing/data.matchers';

describe('AppController (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const module: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = module.createNestApplication();
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
          expect(body.length).toBeGreaterThan(0);
          for (const user of body) {
            expect(user).toEqual(userMatcher);
          }
        }));
    it('/users/:id (GET)', () =>
      request(app.getHttpServer())
        .get('/users/1')
        .expect(200)
        .expect(({ body }) => expect(body).toEqual({ ...userMatcher, id: 1 })));
  });

  describe('chores', () => {
    it('/chores (GET)', () =>
      request(app.getHttpServer())
        .get('/chores')
        .expect(200)
        .expect(({ body }) => {
          expect(body).toBeInstanceOf(Array);
          expect(body.length).toBeGreaterThan(0);
          for (const user of body) {
            expect(user).toEqual(userMatcher);
          }
        }));
    it('/chores/:id (GET)', () =>
      request(app.getHttpServer())
        .get('/chores/1')
        .expect(200)
        .expect(({ body }) => expect(body).toEqual({ ...userMatcher, id: 1 })));
  });
});
