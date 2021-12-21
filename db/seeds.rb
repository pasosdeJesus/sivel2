conexion = ActiveRecord::Base.connection();

# De motores y finalmente de este
motor = ['sip', 'sivel2_gen', nil]
motor.each do |m|
    Sip::carga_semillas_sql(conexion, m, :cambios)
    Sip::carga_semillas_sql(conexion, m, :datos)
end

# usuario sivel2 con clave sivel2
conexion.execute("INSERT INTO public.usuario 
	(id, nusuario, nombre, email, encrypted_password, password, 
  fechacreacion, created_at, updated_at, rol) 
	VALUES (1, 'sivel2', 'sivel2', 'sivel2@localhost', 
	'$2a$10$V2zgaN1ED44UyLy0ubey/.1erdjHYJusmPZnXLyIaHUpJKIATC1nG', 
	'', '2014-08-26', '2014-08-26', '2014-08-26', 1);")

if ENV.fetch('RAILS_ENV', 'development') == 'test'
  conexion.execute("INSERT INTO public.usuario 
  (id, nusuario, nombre, email, encrypted_password, password, 
  fechacreacion, created_at, updated_at, rol) 
  VALUES (2, 'operador', 'operador', 'operador@localhost', 
  '$2a$10$uMAciEcJuUXDnpelfSH6He7BxW0yBeq6VMemlWc5xEl6NZRDYVA3G',
  'sjrcol123', '2014-08-26', '2014-08-26', '2014-08-26', 5);")

  conexion.execute("INSERT INTO public.usuario 
  (id, nusuario, nombre, email, encrypted_password, password, 
  fechacreacion, created_at, updated_at, rol) 
  VALUES (3, 'analista', 'analista', 'analista@localhost', 
  '$2a$10$uMAciEcJuUXDnpelfSH6He7BxW0yBeq6VMemlWc5xEl6NZRDYVA3G',
  'sjrcol123', '2014-08-26', '2014-08-26', '2014-08-26', 5);")
  conexion.execute("INSERT INTO public.sip_grupo_usuario 
  (usuario_id, sip_grupo_id) VALUES (3, 20);")


  conexion.execute("INSERT INTO public.usuario 
  (id, nusuario, nombre, email, encrypted_password, password, 
  fechacreacion, created_at, updated_at, rol) 
  VALUES (4, 'observador', 'observador', 'observador@localhost', 
  '$2a$10$uMAciEcJuUXDnpelfSH6He7BxW0yBeq6VMemlWc5xEl6NZRDYVA3G',
  'sjrcol123', '2014-08-26', '2014-08-26', '2014-08-26', 5);")
  conexion.execute("INSERT INTO public.sip_grupo_usuario 
  (usuario_id, sip_grupo_id) VALUES (4, 21);")


  conexion.execute("INSERT INTO public.usuario 
  (id, nusuario, nombre, email, encrypted_password, password, 
  fechacreacion, created_at, updated_at, rol) 
  VALUES (5, 'observadorparte', 'observadorparte', 
  'observadorparte@localhost', 
  '$2a$10$uMAciEcJuUXDnpelfSH6He7BxW0yBeq6VMemlWc5xEl6NZRDYVA3G',
  'sjrcol123', '2014-08-26', '2014-08-26', '2014-08-26', 5);")
  conexion.execute("INSERT INTO public.sip_grupo_usuario 
  (usuario_id, sip_grupo_id) VALUES (5, 22);")

end
