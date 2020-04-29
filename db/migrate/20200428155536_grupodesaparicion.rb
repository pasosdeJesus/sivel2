class Grupodesaparicion < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      INSERT INTO sip_grupo (id, nombre, fechacreacion, created_at, updated_at)
        VALUES (25, 'Desaparición', 
        '2020-04-28','2020-04-28','2020-04-28');
    SQL
  end

  def down
    execute <<-SQL
      DELETE INTO sip_grupo WHERE id IN (25);
    SQL
  end
end
