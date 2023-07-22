defmodule Mix.Tasks.RunNoHalt do
  use Mix.Task

  @shortdoc "Runs the application without halting"
  def run(args) do
    Mix.Task.run("run", [ "--no-halt" | args ])
  end
end
