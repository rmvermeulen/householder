import { Controller, Get } from '@nestjs/common';
import { UserService } from './user.service';

@Controller('user')
export class UserController {
  constructor(private readonly users: UserService) {}
  @Get()
  getUsers() {
    return this.users.getActiveUsers();
  }
}
