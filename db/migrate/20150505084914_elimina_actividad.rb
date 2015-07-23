class EliminaActividad < ActiveRecord::Migration
  def change
    drop_table :sivel2_gen_actividad_rangoedadac
    drop_table :sivel2_gen_actividadareas_actividad
    drop_table :sivel2_gen_anexoactividad
    drop_table :sivel2_gen_actividad
    drop_table :sivel2_gen_actividadarea
    drop_table :sivel2_gen_rangoedadac
  end
end
