# Concern for common filtering functionality
module Filterable
  extend ActiveSupport::Concern

  private

  def filter_by_status(scope, status_param)
    return scope unless status_param.present?
    
    if status_param.is_a?(Array)
      scope.where(status: status_param)
    else
      scope.where(status: status_param)
    end
  end

  def filter_by_date_range(scope, start_date_param, end_date_param)
    scope = scope.where('created_at >= ?', start_date_param.to_date) if start_date_param.present?
    scope = scope.where('created_at <= ?', end_date_param.to_date.end_of_day) if end_date_param.present?
    scope
  end

  def search_by_name(scope, search_param)
    return scope unless search_param.present?
    
    scope.where("first_name ILIKE ? OR last_name ILIKE ?", "%#{search_param}%", "%#{search_param}%")
  end
end