defmodule MatreexTest do
  use AppCase, async: true

  test "change_sleep" do
    assert %{sleep: 20} = Matreex.change_sleep(%{sleep: 10}, true)
    assert %{sleep: 0} = Matreex.change_sleep(%{sleep: 10}, false)
    assert %{sleep: 0} = Matreex.change_sleep(%{sleep: 0}, false)
  end
end
