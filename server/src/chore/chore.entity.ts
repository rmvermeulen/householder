import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity()
export class Chore {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  title: string;

  @Column()
  description: string;

  @Column()
  deadline: Date;
}
