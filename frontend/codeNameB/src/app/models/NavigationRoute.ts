export class NavigationRoute {
  constructor(
    public path: string,
    public name: string,
    public hasChildren: boolean,
    public children: { path: string; name: string }[],
  ) {}
}
