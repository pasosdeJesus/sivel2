class CreaPrototipoDesaparecidos < ActiveRecord::Migration[6.0]
  def up
    execute <<-EOF
      INSERT INTO public.mr519_gen_formulario (id, nombre, nombreinterno)
        VALUES  (50, 'Desaparición', 'desaparicion');

      INSERT INTO public.mr519_gen_campo (id, nombre, ayudauso, tipo, obligatorio, formulario_id, nombreinterno, fila, columna, ancho, tablabasica) VALUES (200, 'Asegurese de llenar familiares de la persona desaparecida en la pestaña víctima', '', 13, false, 50, 'asegurese_de_llenar_familiares_de_la_persona_desaparecida_en', 2, 1, 12, '');
      INSERT INTO public.mr519_gen_campo (id, nombre, ayudauso, tipo, obligatorio, formulario_id, nombreinterno, fila, columna, ancho, tablabasica) VALUES (201, 'Detalles del primer familiar', '', 13, false, 50, 'detalles_del_primer_familiar', 3, 1, 12, '');
      INSERT INTO public.mr519_gen_campo (id, nombre, ayudauso, tipo, obligatorio, formulario_id, nombreinterno, fila, columna, ancho, tablabasica) VALUES (202, 'Lugar de disposición de cadaveres', '', 2, false, 50, 'lugar_disposicion', 1, 1, 12, '');
      INSERT INTO public.mr519_gen_campo (id, nombre, ayudauso, tipo, obligatorio, formulario_id, nombreinterno, fila, columna, ancho, tablabasica) VALUES (203, 'País de domicilio', '', 14, false, 50, 'pais_de_domicilio', 4, 1, 4, 'paises');
      INSERT INTO public.mr519_gen_campo (id, nombre, ayudauso, tipo, obligatorio, formulario_id, nombreinterno, fila, columna, ancho, tablabasica) VALUES (204, 'Departamento de domicilio', '', 14, false, 50, 'departamento_de_domicilio', 4, 5, 4, 'departamentos');
      INSERT INTO public.mr519_gen_campo (id, nombre, ayudauso, tipo, obligatorio, formulario_id, nombreinterno, fila, columna, ancho, tablabasica) VALUES (205, 'Municipio de domicilio', '', 14, false, 50, 'municipio_de_domicilio', 4, 9, 4, 'municipios');
      INSERT INTO public.mr519_gen_campo (id, nombre, ayudauso, tipo, obligatorio, formulario_id, nombreinterno, fila, columna, ancho, tablabasica) VALUES (206, 'Centro poblado de domicilio', '', 14, false, 50, 'centro_poblado_de_domicilio', 5, 1, 4, 'clases');
      INSERT INTO public.mr519_gen_campo (id, nombre, ayudauso, tipo, obligatorio, formulario_id, nombreinterno, fila, columna, ancho, tablabasica) VALUES (207, 'Dirección de domicilio', '', 1, false, 50, 'direccion_de_domicilio', 5, 5, 4, '');
      INSERT INTO public.mr519_gen_campo (id, nombre, ayudauso, tipo, obligatorio, formulario_id, nombreinterno, fila, columna, ancho, tablabasica) VALUES (208, 'Teléfono', '', 1, false, 50, 'telefono', 5, 9, 4, '');
      INSERT INTO public.mr519_gen_campo (id, nombre, ayudauso, tipo, obligatorio, formulario_id, nombreinterno, fila, columna, ancho, tablabasica) VALUES (209, 'Su relato de la desaparición', '', 2, false, 50, 'su_relato_de_la_desaparicion', 6, 1, 12, '');
      INSERT INTO public.mr519_gen_campo (id, nombre, ayudauso, tipo, obligatorio, formulario_id, nombreinterno, fila, columna, ancho, tablabasica) VALUES (210, 'Instancias a las que ha acudido', '', 2, false, 50, 'instancias_a_las_que_ha_acudido', 7, 1, 12, '');
    EOF
    # formulario 50
    # campo 200
  end

  def down
    execute <<-SQL
      DELETE FROM public.mr519_gen_campo WHERE id>='200' AND id<='210';
      DELETE FROM public.mr519_gen_formulario WHERE id='50';
    SQL
  end

end
