# base-chart

This component will render a few different charts out of the box based on chart type. If importing this without renaming the custom element, you will use `<base-chart>`

## Usage
```typescript
import { ChartJsComponent } from 'path/to/ChartJsComponent.ts';

// doing class extends prevents the ChartJsComponent constructor from failing to initialize in the current scope
customElements.define('your-tag-name', class extends ChartJsComponent {});
```
## Basic markup

```tsx
<your-tag-name chart-type="bar" .config="${someChartData}">
</your-tag-name>
```

## Properties

| Property        | Attribute      | Type                                             | Default     | Description                                      |
|-----------------|----------------|--------------------------------------------------|-------------|--------------------------------------------------|
| `canvasElement` |                | `HTMLCanvasElement \| undefined`                 |             |                                                  |
| `chart`         |                | `Chart<keyof ChartTypeRegistry, (number \| [number, number] \| Point \| BubbleDataPoint \| null)[], unknown> \| undefined` |             |                                                  |
| `chartType`     | `chart-type`   | `ChartType`                                      | "undefined" | This is the type based on the data in the chart-js typing. |
| `config`        | `chart-config` | `Object`                                         | "undefined" | This is the chart config based on the chart JS configuration options in their site and documentation. Currently supported types are bar, pie, and doughnut. More are coming. |
