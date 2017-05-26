class SoloRolesValidos < ActiveRecord::Migration[5.0]
  def up
    execute <<-SQL
      UPDATE usuario SET rol='5' WHERE rol NOT IN ('1', '5');
    SQL
  end
  def down
    raise ActiveRecord::IrreversibleMigration 
  end
end
