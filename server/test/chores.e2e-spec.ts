import { INestApplication } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import * as request from 'supertest';
import { EntityManager } from 'typeorm';
import { Chore } from '../src/chore/chore.entity';
import { ChoreModule } from '../src/chore/chore.module';
import { choreMatcher } from '../src/testing/data.matchers';
import { databaseTestingModule } from '../src/testing/database.module';

describe('AppController (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const module: TestingModule = await Test.createTestingModule({
      imports: [databaseTestingModule, ChoreModule],
    }).compile();

    const mgr: EntityManager = module.get(EntityManager);
    await mgr.save([
      await mgr.create(Chore, {
        id: 12,
        title: 'test',
        description: 'testing',
        deadline: Date.now(),
      }),
      await mgr.create(Chore, {
        id: 16,
        title: 'test',
        description: 'testing',
        deadline: Date.now(),
      }),
    ]);

    app = module.createNestApplication();
    await app.init();
  });

  afterAll(() => app.close());

  describe('chores', () => {
    it('/chores (GET)', () =>
      request(app.getHttpServer())
        .get('/chores')
        .expect(200)
        .expect(({ body }) => {
          expect(body).toBeInstanceOf(Array);
          expect(body.length).toBeGreaterThan(0);
          for (const user of body) {
            expect(user).toEqual(choreMatcher);
          }
        }));
    it('/chores/:id (GET)', () =>
      request(app.getHttpServer())
        .get('/chores/12')
        .expect(200)
        .expect(({ body }) =>
          expect(body).toEqual({ ...choreMatcher, id: 12 }),
        ));
  });
});
