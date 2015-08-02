class UsuarioGustosController < ApplicationController
  before_action :set_usuario_gusto, only: [:show, :edit, :update, :destroy]

  # GET /usuario_gustos
  # GET /usuario_gustos.json
  def index
    @usuario_gustos = UsuarioGusto.all
  end

  # GET /usuario_gustos/1
  # GET /usuario_gustos/1.json
  def show
  end

  # GET /usuario_gustos/new
  def new
    @usuario_gusto = UsuarioGusto.new
  end

  # GET /usuario_gustos/1/edit
  def edit
  end

  # POST /usuario_gustos
  # POST /usuario_gustos.json
  def create
    @usuario_gusto = UsuarioGusto.new(usuario_gusto_params)

    respond_to do |format|
      if @usuario_gusto.save
        format.html { redirect_to @usuario_gusto, notice: 'Usuario gusto was successfully created.' }
        format.json { render action: 'show', status: :created, location: @usuario_gusto }
      else
        format.html { render action: 'new' }
        format.json { render json: @usuario_gusto.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /usuario_gustos/1
  # PATCH/PUT /usuario_gustos/1.json
  def update
    respond_to do |format|
      if @usuario_gusto.update(usuario_gusto_params)
        format.html { redirect_to @usuario_gusto, notice: 'Usuario gusto was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @usuario_gusto.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /usuario_gustos/1
  # DELETE /usuario_gustos/1.json
  def destroy
    @usuario_gusto.destroy
    respond_to do |format|
      format.html { redirect_to usuario_gustos_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_usuario_gusto
      @usuario_gusto = UsuarioGusto.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def usuario_gusto_params
      params.require(:usuario_gusto).permit(:idUsuarioGusto, :idGustoU, :idUsuarioG)
    end
end
