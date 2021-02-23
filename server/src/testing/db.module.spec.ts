import { TestingModule, Test } from '@nestjs/testing';
import { EntityManager } from 'typeorm';
import { dbModule } from './db.module';

describe('Database testing module', () => {
  it('is required for database services', async () => {
    const module: TestingModule = await Test.createTestingModule({}).compile();
    expect(() => module.get(EntityManager)).toThrow();
  });
  it('provides the services we want to be able to mock', async () => {
    const module: TestingModule = await Test.createTestingModule({
      imports: [dbModule],
    }).compile();
    const mgr: EntityManager = module.get(EntityManager);
    expect(mgr).toBeDefined();
  });
});
