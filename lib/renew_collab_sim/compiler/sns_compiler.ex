defmodule RenewCollabSim.Compiler.SnsCompiler do
  def compile(formalism, nets) do
    {:ok, compiler} = compiler_name(formalism)

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
          normalized_name = normalize_net_name(name)
          {:ok, name} = Path.safe_relative_to(normalized_name, output_root_upload)
          net_file_name = Path.absname(name, output_root_upload)
          File.write(net_file_name, content)

          net_file_name
        end

      script_content =
        [
          "setFormalism #{compiler}",
          "ex ShadowNetSystem -a #{Enum.join(paths |> Enum.map(&"\"#{&1}\""), " ")} -o \"#{output_path}\""
        ]
        |> Enum.join("\n")

      File.write!(script_path, script_content)

      with {:ok, 0} <- RenewCollabSim.Script.Runner.start_and_wait(script_path),
           {:ok, content} when content != [] <- File.read(output_path) do
        {:ok, content}
      else
        e ->
          {:error, e}
      end
    after
      File.rm_rf(output_root_upload)
    end
  end

  def compiler_name(c) do
    if Enum.member?(formalisms(), c) do
      {:ok, c}
    else
      {:error, :c}
    end
  end

  def formalisms(), do: Application.fetch_env!(:renew_collab, :formalisms)

  def default_formalism(), do: formalisms() |> List.first()

  def normalize_net_name(name) do
    String.split(name, ".") |> List.first() |> String.trim()
  end
end
