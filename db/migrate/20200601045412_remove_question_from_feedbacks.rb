class RemoveQuestionFromFeedbacks < ActiveRecord::Migration[6.0]
  def change
    remove_column :feedbacks, :question, :string
  end
end
