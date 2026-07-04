using System.Collections;
using System.Linq.Expressions;
using Microsoft.EntityFrameworkCore.Query;

namespace EG.UnidTest.Support;

internal sealed class TestAsyncEnumerable<T> : EnumerableQuery<T>, IAsyncEnumerable<T>, IQueryable<T>
{
    public TestAsyncEnumerable(IEnumerable<T> enumerable)
        : base(enumerable)
    {
    }

    public TestAsyncEnumerable(Expression expression)
        : base(expression)
    {
    }

    public IAsyncEnumerator<T> GetAsyncEnumerator(CancellationToken cancellationToken = default)
    {
        return new TestAsyncEnumerator<T>(this.AsEnumerable().GetEnumerator());
    }

    IQueryProvider IQueryable.Provider => new TestAsyncQueryProvider<T>(this);
}

internal sealed class TestAsyncEnumerator<T>(IEnumerator<T> inner) : IAsyncEnumerator<T>
{
    public T Current => inner.Current;

    public ValueTask DisposeAsync()
    {
        inner.Dispose();
        return ValueTask.CompletedTask;
    }

    public ValueTask<bool> MoveNextAsync()
    {
        return ValueTask.FromResult(inner.MoveNext());
    }
}

internal sealed class TestAsyncQueryProvider<TEntity>(IQueryProvider inner) : IAsyncQueryProvider
{
    public IQueryable CreateQuery(Expression expression)
    {
        return new TestAsyncEnumerable<TEntity>(expression);
    }

    public IQueryable<TElement> CreateQuery<TElement>(Expression expression)
    {
        return new TestAsyncEnumerable<TElement>(expression);
    }

    public object? Execute(Expression expression)
    {
        return inner.Execute(expression);
    }

    public TResult Execute<TResult>(Expression expression)
    {
        return inner.Execute<TResult>(expression);
    }

    public TResult ExecuteAsync<TResult>(Expression expression, CancellationToken cancellationToken = default)
    {
        var expectedResultType = typeof(TResult).GetGenericArguments()[0];
        var executionResult = typeof(IQueryProvider)
            .GetMethods()
            .Single(method => method.Name == nameof(IQueryProvider.Execute)
                && method.IsGenericMethod
                && method.GetParameters().Length == 1)
            .MakeGenericMethod(expectedResultType)
            .Invoke(inner, [expression]);

        return (TResult)typeof(Task)
            .GetMethod(nameof(Task.FromResult))!
            .MakeGenericMethod(expectedResultType)
            .Invoke(null, [executionResult])!;
    }
}
