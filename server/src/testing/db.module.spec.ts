import { TestingModule, Test } from '@nestjs/testing';
import { EntityManager } from 'typeorm';
import { databaseTestingModule } from './database.module';

describe('Database testing module', () => {
  it('is required for database services', async () => {
    const module: TestingModule = await Test.createTestingModule({}).compile();
    expect(() => module.get(EntityManager)).toThrow();
  });
  it('provides the services we want to be able to mock', async () => {
    const module: TestingModule = await Test.createTestingModule({
      imports: [databaseTestingModule],
    }).compile();
    const mgr: EntityManager = module.get(EntityManager);
    expect(mgr).toBeDefined();
  });
});
