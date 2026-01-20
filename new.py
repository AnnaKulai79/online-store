import pandas as pd

data = {
    'product_id': [0, 1],
    'store1': [95, 70],
    'store2': [100, None],
    'store3': [105, 80]
}
df = pd.DataFrame(data)
df_long = df.melt(
    id_vars = ['product_id'], 
    value_vars = ['store1', 'store2', 'store3'],
    var_name = 'store',
    value_name = 'price'
)
df_long = df_long.dropna(subset=['price'])
# return df_long[['product_id', 'store', 'price']]
# return pd.melt(products, id_vars='product_id', var_name='store', value_name='price').dropna()
df_stack = df.set_index('product_id').stack()#.reset_index()
# df_stack.columns = ['product_id', 'store', 'price']
print(df)
print(df_stack)
print(df_long)
