def expect_count_to_change(count = 1, &block)
  expect { block.call }.to change(ResqueValue, :count).by(count)
end

def expect_count_to_not_change(&block)
  expect { block.call }.to_not change(ResqueValue, :count)
end