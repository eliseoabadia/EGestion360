using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EG.Common.Util
{
    public static class Utilities
    {
        public static TTarget CopyModelValues<TSource, TTarget>(TSource source) where TTarget : new()
        {
            if (source == null)
                throw new ArgumentNullException(nameof(source));

            var sourceProperties = typeof(TSource).GetProperties().Where(p => p.CanRead);
            var targetProperties = typeof(TTarget).GetProperties().Where(p => p.CanWrite);

            var target = new TTarget();

            foreach (var sourceProperty in sourceProperties)
            {
                var targetProperty = targetProperties.FirstOrDefault(p => p.Name == sourceProperty.Name && p.PropertyType == sourceProperty.PropertyType);
                if (targetProperty != null)
                {
                    targetProperty.SetValue(target, sourceProperty.GetValue(source, null), null);
                }
            }

            return target;
        }


        public static TTarget Transform<TSource, TTarget>(TSource source)
    where TTarget : new()
        {
            var target = new TTarget();
            var sourceProperties = typeof(TSource).GetProperties().Where(p => p.CanRead);
            var targetProperties = typeof(TTarget).GetProperties().Where(p => p.CanWrite);

            foreach (var sourceProperty in sourceProperties)
            {
                var targetProperty = targetProperties.FirstOrDefault(p => p.Name == sourceProperty.Name && p.PropertyType == sourceProperty.PropertyType);
                if (targetProperty != null)
                {
                    var value = sourceProperty.GetValue(source);
                    targetProperty.SetValue(target, value);
                }
            }

            return target;
        }

        public static TTarget[] TransformArray<TSource, TTarget>(TSource[] sourceArray)
            where TTarget : new()
        {
            return sourceArray.Select(source => Transform<TSource, TTarget>(source)).ToArray();
        }


        public static DataTable ListToDataTable<T>(this List<T> items)
        {
            var dataTable = new DataTable(typeof(T).Name);
            var properties = typeof(T).GetProperties();

            foreach (var property in properties)
            {
                var columnType = property.PropertyType;

                // Handle nullable types
                if (columnType.IsGenericType && columnType.GetGenericTypeDefinition() == typeof(Nullable<>))
                {
                    columnType = Nullable.GetUnderlyingType(columnType);
                }

                dataTable.Columns.Add(property.Name, columnType);
            }

            foreach (var item in items)
            {
                var row = dataTable.NewRow();

                foreach (var property in properties)
                {
                    row[property.Name] = property.GetValue(item) ?? DBNull.Value;
                }

                dataTable.Rows.Add(row);
            }

            return dataTable;
        }

        public static DataTable ItemToDataTable<T>(this T item)
        {
            var dataTable = new DataTable(typeof(T).Name);
            var properties = typeof(T).GetProperties();

            // Crear columnas
            foreach (var property in properties)
            {
                var columnType = property.PropertyType;

                // Manejar tipos anulables
                if (columnType.IsGenericType && columnType.GetGenericTypeDefinition() == typeof(Nullable<>))
                {
                    columnType = Nullable.GetUnderlyingType(columnType);
                }

                dataTable.Columns.Add(property.Name, columnType);
            }

            // Agregar fila
            var row = dataTable.NewRow();
            foreach (var property in properties)
            {
                row[property.Name] = property.GetValue(item) ?? DBNull.Value;
            }
            dataTable.Rows.Add(row);

            return dataTable;
        }
    }
}
