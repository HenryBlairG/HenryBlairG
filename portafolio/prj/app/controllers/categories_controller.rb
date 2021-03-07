# frozen_string_literal: true

# Category Controller
class CategoriesController < ApplicationController
  # before_action :set_user, only: %i[show edit update destroy]
  before_action :require_permission

  # GET /categories/new
  def new
    @category = Category.new
  end

  # POST /categories
  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to categories_path, notice: 'Category was successfully created.'
    else
      render :new
    end
  end

  # GET /categories
  def index
    @categories = Category.all
  end

  private

  # Only allow a list of trusted parameters through.
  def category_params
    params.require(:category).permit(:name)
  end

  def require_permission
    is_admin = user_signed_in? && current_user.admin
    correct_user = user_signed_in? && current_user
    has_permission = is_admin && correct_user
    notice = 'You don\'t have the permissions to do that'

    redirect_to root_path, notice: notice unless has_permission
  end
end
