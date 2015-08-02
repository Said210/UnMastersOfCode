class UsuarioSitiosController < ApplicationController
  before_action :set_usuario_sitio, only: [:show, :edit, :update, :destroy]

  # GET /usuario_sitios
  # GET /usuario_sitios.json
  def index
    @usuario_sitios = UsuarioSitio.all
  end

  # GET /usuario_sitios/1
  # GET /usuario_sitios/1.json
  def show
  end

  # GET /usuario_sitios/new
  def new
    @usuario_sitio = UsuarioSitio.new
  end

  # GET /usuario_sitios/1/edit
  def edit
  end

  # POST /usuario_sitios
  # POST /usuario_sitios.json
  def create
    @usuario_sitio = UsuarioSitio.new(usuario_sitio_params)

    respond_to do |format|
      if @usuario_sitio.save
        format.html { redirect_to @usuario_sitio, notice: 'Usuario sitio was successfully created.' }
        format.json { render action: 'show', status: :created, location: @usuario_sitio }
      else
        format.html { render action: 'new' }
        format.json { render json: @usuario_sitio.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /usuario_sitios/1
  # PATCH/PUT /usuario_sitios/1.json
  def update
    respond_to do |format|
      if @usuario_sitio.update(usuario_sitio_params)
        format.html { redirect_to @usuario_sitio, notice: 'Usuario sitio was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @usuario_sitio.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /usuario_sitios/1
  # DELETE /usuario_sitios/1.json
  def destroy
    @usuario_sitio.destroy
    respond_to do |format|
      format.html { redirect_to usuario_sitios_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_usuario_sitio
      @usuario_sitio = UsuarioSitio.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def usuario_sitio_params
      params.require(:usuario_sitio).permit(:idUsuarioSitio, :idUsuarioS, :idSitioU)
    end
end
