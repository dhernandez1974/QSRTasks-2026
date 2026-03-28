class Organization::Comments::CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_comment, only: %i[ show edit update destroy ]

  # GET /organization/comments/comments
  def index
    @comments = policy_scope(Organization::Comment.all)
  end

  # GET /organization/comments/comments/1
  def show
    authorize @comment
  end

  # GET /organization/comments/comments/new
  def new
    @comment = Organization::Comment.new
    authorize @comment
  end

  # GET /organization/comments/comments/1/edit
  def edit
    authorize @comment
  end

  # POST /organization/comments/comments
  def create
    @comment = Organization::Comment.new(comment_params)
    authorize @comment

    respond_to do |format|
      if @comment.save
        format.html { redirect_to organization_comments_comment_path(@comment), notice: "Comment was successfully created." }
        format.json { render :show, status: :created, location: @comment }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /organization/comments/comments/1
  def update
    authorize @comment
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to organization_comments_comment_path(@comment), notice: "Comment was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @comment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organization/comments/comments/1
  def destroy
    authorize @comment
    @comment.destroy!

    respond_to do |format|
      format.html { redirect_to organization_comments_comments_path, notice: "Comment was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Organization::Comment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def comment_params
      params.require(:organization_comment).permit(:location_id, :organization_id, :order_point, :pickup_point, :parent, :case_number, :parent_case_number, :case_origin, :visit_time, :visit_date, :customer_comments, :issue_category, :issue_reason, :issue_subcode, :propel, :comment_type, :employee_named_id, :status, :user_id, :source)
    end
end
