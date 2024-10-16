import { CommonModule } from '@angular/common';
import { Component, Input } from '@angular/core';

@Component({
  selector: 'app-loading-screen',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './loading-screen.component.html',
  styleUrl: './loading-screen.component.scss',
})
export class LoadingScreenComponent {
  @Input()
  public show: boolean = false;
}
