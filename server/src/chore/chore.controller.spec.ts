import { Test, TestingModule } from '@nestjs/testing';
import { ChoreController } from './chore.controller';
import { ChoreService } from './chore.service';

describe('ChoreController', () => {
  let controller: ChoreController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [ChoreService],
      controllers: [ChoreController],
    })
      .overrideProvider(ChoreService)
      .useValue({})
      .compile();

    controller = module.get<ChoreController>(ChoreController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
