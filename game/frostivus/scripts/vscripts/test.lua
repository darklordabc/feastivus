local a = {1,2,3,4}
a[2] = nil
table.sort(a, function(a, b) return a > b end)