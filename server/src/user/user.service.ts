import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './user.entity';

@Injectable()
export class UserService {
  constructor(
    @InjectRepository(User) private readonly users: Repository<User>,
  ) {}
  async getUsers(): Promise<User[]> {
    return this.users.find();
  }

  async getActiveUsers(): Promise<User[]> {
    return this.users.find({ isActive: true });
  }

  async getUser(id: number): Promise<User> {
    return this.users.findOne({ id });
  }

  async createUser(
    data: Partial<User & { firstName: string; lastName: string }>,
  ): Promise<User> {
    return this.users.save(data);
  }
}
