import pandas as pd

# 从 Excel 文件导入数据
input_file = "D:\Desktop\data1.xlsx" # 输入文件路径
output_file = "D:/Desktop/data.xlsx"  # 输出文件路径

# 读取 Excel 文件
df = pd.read_excel(input_file)

# 对每一列进行后一个值减前一个值的操作
diff_df = df.diff()

# 保存结果到新的 Excel 文件
diff_df.to_excel(output_file, index=False)

print(f"差值结果已保存到 Excel 文件：{output_file}")