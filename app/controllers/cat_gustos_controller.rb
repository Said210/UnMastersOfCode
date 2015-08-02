class CatGustosController < ApplicationController
  before_action :set_cat_gusto, only: [:show, :edit, :update, :destroy]

  # GET /cat_gustos
  # GET /cat_gustos.json
  def index
    @cat_gustos = CatGusto.all
  end

  # GET /cat_gustos/1
  # GET /cat_gustos/1.json
  def show
  end

  # GET /cat_gustos/new
  def new
    @cat_gusto = CatGusto.new
  end

  # GET /cat_gustos/1/edit
  def edit
  end

  # POST /cat_gustos
  # POST /cat_gustos.json
  def create
    @cat_gusto = CatGusto.new(cat_gusto_params)

    respond_to do |format|
      if @cat_gusto.save
        format.html { redirect_to @cat_gusto, notice: 'Cat gusto was successfully created.' }
        format.json { render action: 'show', status: :created, location: @cat_gusto }
      else
        format.html { render action: 'new' }
        format.json { render json: @cat_gusto.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cat_gustos/1
  # PATCH/PUT /cat_gustos/1.json
  def update
    respond_to do |format|
      if @cat_gusto.update(cat_gusto_params)
        format.html { redirect_to @cat_gusto, notice: 'Cat gusto was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @cat_gusto.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cat_gustos/1
  # DELETE /cat_gustos/1.json
  def destroy
    @cat_gusto.destroy
    respond_to do |format|
      format.html { redirect_to cat_gustos_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cat_gusto
      @cat_gusto = CatGusto.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cat_gusto_params
      params.require(:cat_gusto).permit(:idGusto, :gusto)
    end
end
