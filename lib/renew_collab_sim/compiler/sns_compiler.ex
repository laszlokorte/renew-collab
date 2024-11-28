defmodule RenewCollabSim.Compiler.SnsCompiler do
  def compile(nets) do
    uuid_dir = "renew-ssn-compilation-#{UUID.uuid4(:default)}"
    {:ok, output_root} = Path.safe_relative_to(uuid_dir, System.tmp_dir!())
    output_root = Path.absname(output_root, System.tmp_dir!())

    {:ok, output_root_upload} = Path.safe_relative_to("uploads", output_root)

    {:ok, output_path} = Path.safe_relative_to("compiled.ssn", output_root)
    {:ok, script_path} = Path.safe_relative_to("compile-script", output_root)

    output_root_upload = Path.absname(output_root_upload, output_root)
    output_path = Path.absname(output_path, output_root)
    script_path = Path.absname(script_path, output_root)

    try do
      File.mkdir_p(output_root_upload)

      paths =
        for {name, content} <- nets do
          {:ok, name} = Path.safe_relative_to(name, output_root_upload)
          net_file_name = Path.absname(name, output_root_upload)
          File.write(net_file_name, content)

          net_file_name
        end

      script_content =
        [
          "setFormalism Java Net Compiler",
          "ex ShadowNetSystem -a #{Enum.join(paths, " ")} -o #{output_path}"
        ]
        |> Enum.join("\n")

      File.write!(script_path, script_content)

      with {:ok, 0} <- RenewCollabSim.Script.Runner.start_and_wait(script_path),
           {:ok, content} <- File.read(output_path) do
        {:ok, content}
      else
        _ ->
          :error
      end
    after
      File.rm_rf(output_root_upload)
    end
  end
end
