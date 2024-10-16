import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'toMinutes',
  standalone: true,
})
export class SecondsToMinutesPipe implements PipeTransform {
  transform(value: number): string {
    const seconds = value % 60;
    const minutes = Math.floor(value / 60);
    return minutes + ':' + seconds;
  }
}
