import { Test, TestingModule } from '@nestjs/testing';
import { TypeOrmModule } from '@nestjs/typeorm';
import { databaseTestingModule } from '../testing/database.module';
import { choreMatcher } from '../testing/data.matchers';
import { Chore } from './chore.entity';
import { ChoreService } from './chore.service';
import { EntityManager } from 'typeorm';

describe('ChoreService', () => {
  let service: ChoreService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      imports: [databaseTestingModule, TypeOrmModule.forFeature([Chore])],
      providers: [ChoreService],
    }).compile();

    const mgr: EntityManager = module.get(EntityManager);
    await mgr.save([
      await mgr.create(Chore, {
        id: 3,
        title: 'test',
        description: 'testing',
        deadline: new Date(),
      }),
      await mgr.create(Chore, {
        id: 4,
        title: 'test',
        description: 'testing',
        deadline: new Date(),
      }),
    ]);

    service = module.get<ChoreService>(ChoreService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('can find all chores', async () => {
    const chores = await service.find();
    expect(chores).toEqual(
      expect.arrayContaining([choreMatcher, choreMatcher]),
    );
  });

  it('can find a specific chore', () =>
    expect(service.findById(4)).resolves.toEqual({ ...choreMatcher, id: 4 }));
});
