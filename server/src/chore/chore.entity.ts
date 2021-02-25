import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';
import { IsDate } from 'class-validator';

@Entity()
export class Chore {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  title: string;

  @Column()
  description: string;

  @Column()
  @IsDate()
  deadline: Date;
}
