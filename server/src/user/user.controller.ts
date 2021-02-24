import { Controller, Get, Param } from '@nestjs/common';
import { UserService } from './user.service';

@Controller('users')
export class UserController {
  constructor(private readonly users: UserService) {}
  @Get()
  getUsers() {
    return this.users.getActiveUsers();
  }
  @Get('/:id')
  async getUser(@Param('id') id: number) {
    return this.users.getUser(id);
  }
}
