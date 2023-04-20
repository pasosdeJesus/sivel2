class QuitaApo214 < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      DROP TABLE IF EXISTS apo214_asisreconocimiento CASCADE;
      DROP TABLE IF EXISTS apo214_cobertura CASCADE;
      DROP TABLE IF EXISTS apo214_disposicioncadaveres CASCADE;
      DROP TABLE IF EXISTS apo214_elementopaisaje CASCADE;
      DROP TABLE IF EXISTS apo214_evaluacionriesgo CASCADE;
      DROP TABLE IF EXISTS apo214_infoanomalia CASCADE;
      DROP TABLE IF EXISTS apo214_infoanomalialugar CASCADE;
      DROP TABLE IF EXISTS apo214_listaanexo CASCADE;
      DROP TABLE IF EXISTS apo214_listadepositados CASCADE;
      DROP TABLE IF EXISTS apo214_listaevariesgo CASCADE;
      DROP TABLE IF EXISTS apo214_listainfofoto CASCADE;
      DROP TABLE IF EXISTS apo214_listainfofoto CASCADE;
      DROP TABLE IF EXISTS apo214_listapersofuentes CASCADE;
      DROP TABLE IF EXISTS apo214_listasuelo CASCADE;
      DROP TABLE IF EXISTS apo214_lugarpreliminar CASCADE;
      DROP TABLE IF EXISTS apo214_propietario CASCADE;
      DROP TABLE IF EXISTS apo214_riesgo CASCADE;
      DROP TABLE IF EXISTS apo214_suelo CASCADE;
      DROP TABLE IF EXISTS apo214_tipoentierro CASCADE;
      DROP TABLE IF EXISTS apo214_tipotestigo CASCADE;
    SQL
  end
  def down
  end
end
