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


let () = 
  match Unix.fork () with
    | 0 -> 				(* child *)
      Unix.execv temp_top (
	Array.append [|temp_top|]
	  (Array.append [|"-init"; temp_init; "-I"; include_path|]
	     (Array.sub Sys.argv ~pos:1 ~len:(Array.length Sys.argv - 1))
	  )
      )
    | _pid -> 				(* parent *)
      let (_pid, status) = Unix.wait () in
      (* cleanup *)
      Unix.unlink temp_top;
      Unix.unlink temp_init;
      match status with
	| Unix.WEXITED i -> exit i
	| Unix.WSIGNALED i -> Printf.eprintf "signaled %d\n" i; exit 0
	| Unix.WSTOPPED i -> Printf.eprintf "stopped %d\n" i; exit 0

