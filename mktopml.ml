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
    | [|_program;output_file;toplevel;ocamlinit;mktop_ml|] ->
      let oc = open_out output_file in
      output_string oc "let top = \"";
      let top_ic = open_in toplevel in
      write_escaped oc top_ic;
      close_in top_ic;
      output_string oc "\";;\n\n";
      output_string oc "let init = \"";
      let init_ic = open_in ocamlinit in
      write_escaped oc init_ic;
      close_in init_ic;
      output_string oc "\";;\n\n";
      let mktop_ml_ic = open_in mktop_ml in
      write oc mktop_ml_ic;
      close_in mktop_ml_ic;
      close_out oc
    | _ -> failwith "invalid usage"

