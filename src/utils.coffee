# ネストされた配列をフラットな配列にする
exports.flatten = flatten = (array, results = []) ->
  for item in array
    if Array.isArray(item)
      flatten(item, results)
    else
      results.push(item)
  results
# toArray
exports.toArray = (value = []) ->
  if Array.isArray(value) then value else [value]