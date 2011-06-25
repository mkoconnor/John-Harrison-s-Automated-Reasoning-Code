open StdLabels

let write_gen ~f = (); fun oc ic ->
  let buf = String.create 1024 in
  let still_reading = ref true in
  while !still_reading do
    let num_chars = input ic buf 0 1024 in
    if num_chars = 0
    then still_reading := false
    else 
      output_string oc (f (String.sub buf ~pos:0 ~len:num_chars))
  done

let write_escaped = write_gen ~f:String.escaped
let write = write_gen ~f:(fun s -> s)

let () = 
  match Sys.argv with
    | [|_program;output_file;toplevel;ocamlinit;mktop_ml;include_path|] ->
      let oc = open_out output_file in
      let define_var var ~write_escaped = 
	output_string oc "let ";
	output_string oc var;
	output_string oc " = \"";
	write_escaped oc;
	output_string oc "\";;\n\n"
      in
      let define_var_escaped var ~file = 
	define_var var ~write_escaped:(fun oc ->
	  let ic = open_in file in
	  write_escaped oc ic;
	  close_in ic
	)
      in
      define_var_escaped "top" toplevel;
      define_var_escaped "init" ocamlinit;
      define_var "include_path" ~write_escaped:(fun oc ->
	output_string oc (String.escaped include_path)
      );
      let mktop_ml_ic = open_in mktop_ml in
      write oc mktop_ml_ic;
      close_in mktop_ml_ic;
      close_out oc
    | _ -> failwith "invalid usage"

