class CreateSubTasks < ActiveRecord::Migration[4.2]
  def change
    create_table :sub_tasks do |t|
      t.datetime :completion_date
      t.references :sub_task_definition
      t.references :task

      t.timestamps
    end
  end
end
