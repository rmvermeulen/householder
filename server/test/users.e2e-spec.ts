import { INestApplication } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import * as request from 'supertest';
import { EntityManager } from 'typeorm';
import { userMatcher } from '../src/testing/data.matchers';
import { databaseTestingModule } from '../src/testing/database.module';
import { User } from '../src/user/user.entity';
import { UserModule } from '../src/user/user.module';

describe('AppController (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const module: TestingModule = await Test.createTestingModule({
      imports: [databaseTestingModule, UserModule],
    }).compile();

    const mgr: EntityManager = module.get(EntityManager);
    await mgr.save([
      await mgr.create(User, {
        firstName: 'test',
        lastName: 'testing',
        isActive: true,
      }),
      await mgr.create(User, {
        firstName: 'inactive',
        lastName: 'testing',
        isActive: false,
      }),
    ]);

    app = module.createNestApplication();
    await app.init();
  });

  afterAll(() => app.close());

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
});
