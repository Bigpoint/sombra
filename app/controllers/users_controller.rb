class UsersController < SecuredController
  before_action :set_user, only: [:show, :update, :destroy]

  # GET /users
  def index
    authorize! :read, User
    @users = User.all

    render json: @users
  end

  # GET /users/1
  def show
    authorize! :read, User
    render json: @user
  end

  # POST /users
  def create
    authorize! :create, User
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    authorize! :update, User
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    authorize! :destroy, User
    @user.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:name, :password, :role)
    end
end
