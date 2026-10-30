from numbers import Number

from .schemas import ChartSpec, QueryResult

ALLOWED_CHART_TYPES = {"auto", "table", "metric", "line", "bar", "pie", "scatter"}


def build_chart_spec(
    result: QueryResult, title: str, preferred: str = "auto", suggested: str = "auto"
) -> ChartSpec:
    columns = result.columns
    if not result.rows or not columns:
        return ChartSpec(type="table", title=title)
    chart_type = (
        preferred if preferred in ALLOWED_CHART_TYPES and preferred != "auto" else suggested
    )
    if chart_type not in ALLOWED_CHART_TYPES or chart_type == "auto":
        if len(columns) == 1 and len(result.rows) == 1:
            chart_type = "metric"
        elif len(columns) >= 2 and any(
            token in columns[0].lower() for token in ("date", "time", "month", "year")
        ):
            chart_type = "line"
        elif len(columns) >= 2:
            chart_type = "bar"
        else:
            chart_type = "table"

    numeric_columns = [
        column
        for column in columns[1:]
        if any(isinstance(row.get(column), Number) for row in result.rows)
    ]
    if chart_type in {"line", "bar", "pie", "scatter"} and not numeric_columns:
        chart_type = "table"
    return ChartSpec(
        type=chart_type,
        title=title,
        xField=columns[0] if len(columns) > 1 else None,
        yFields=numeric_columns[:3],
        seriesNames={column: column.replace("_", " ") for column in numeric_columns[:3]},
        smooth=chart_type == "line",
    )
