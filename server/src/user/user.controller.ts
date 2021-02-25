import { Controller, Get, Param } from '@nestjs/common';
import { UserService } from './user.service';

@Controller(['user', 'users'])
export class UserController {
  constructor(private readonly users: UserService) {}

  @Get()
  getUsers() {
    return this.users.getActiveUsers();
  }

  @Get('/:id')
  async getUser(@Param('id') id: number) {
    return this.users.findById(id);
  }
}
