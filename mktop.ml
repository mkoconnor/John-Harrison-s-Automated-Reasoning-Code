open StdLabels

let temp_top = 
  let f = Filename.temp_file "ocamltop" ".exe" in
  Unix.chmod f 0o700;
  f

let temp_init = Filename.temp_file "ocamltop" ".init"

let write ~file ~string = 
  let oc = open_out_bin file in
  output_string oc string;
  close_out oc

let () = write ~file:temp_top ~string:top
let () = write ~file:temp_init ~string:init

let () = Unix.execv temp_top (
  Array.append [|temp_top|]
    (Array.append [|"-init"; temp_init|]
       (Array.sub Sys.argv ~pos:1 ~len:(Array.length Sys.argv - 1))
    )
)
