extends CSGCombiner

var button_csg = Button.new()
var object_name = ""
var obj = null

var objcont = "" #.obj content
var matcont = "" #.mat content

var model = []
var prev_model = []
var voxel_scale = 0.1

func update_model():
	for child in get_children():
		child.queue_free()
	
	for i in model:
		create_voxel(Vector3(i[0]*voxel_scale, i[1]*voxel_scale, i[2]*voxel_scale), Color(i[3],i[4],i[5]))
func create_voxel(pos: Vector3, color: Color):
	var voxel = CSGBox.new()
	#Transforms
	voxel.width = voxel_scale
	voxel.height = voxel_scale
	voxel.depth = voxel_scale
	voxel.global_translation = pos
	# Material
	apply_color_to_voxel(voxel, color)
	add_child(voxel)
func apply_color_to_voxel(voxel: CSGBox, color: Color) -> void:
	# Material
	var voxel_material = SpatialMaterial.new()
	voxel_material.albedo_color = color
	voxel.material = voxel_material
func add_voxel(pos: Vector3, color:Color):
	prev_model = []
	prev_model.append_array(model)
	
	create_voxel(pos*voxel_scale, color)
	model.append([pos.x, pos.y, pos.z, color.r, color.g, color.b])
	
	
	
	#update_model()
func remove_voxel(pos: Vector3) -> void:
	if get_voxel_in_model(pos) != null:
		model.remove(get_voxel_in_model(pos))
		get_voxel_in_tree(pos).queue_free()
		#update_model()
func paint_voxel(pos: Vector3, color: Color) -> void:
	if get_voxel_in_model(pos) == null: return
	var index = model[get_voxel_in_model(pos)]
	index[3] = color.r
	index[4] = color.g 
	index[5] = color.b
	apply_color_to_voxel(get_voxel_in_tree(pos), color)

func get_voxel_in_tree(pos: Vector3):
	for i in get_children():
		var i_pos = i.translation
		if i_pos == pos*voxel_scale:
			return i
func get_voxel_in_model(pos: Vector3):
	var index = 0
	for i in model:
		var i_pos = Vector3(i[0], i[1], i[2])
		if i_pos == pos:
			return(index)
		index += 1
func undo():
	model = prev_model
	update_model()
func _input(event):
	if Input.is_action_just_pressed("undo"): undo()
func _ready():
	update_model()
	obj = self
	object_name = name
func exportcsg():
	#Variables
	objcont = "" #.obj content
	matcont = "" #.mat content
	var csgMesh= obj.get_meshes();
	var vertcount=0
	
	#OBJ Headers
	objcont+="mtllib "+object_name+".mtl\n"
	objcont+="o " + object_name + "\n";#CHANGE WITH SELECTION NAME";
	
	#Blank material
	var blank_material = SpatialMaterial.new()
	blank_material.resource_name = "BlankMaterial"
	
	#Get surfaces and mesh info
	for t in range(csgMesh[-1].get_surface_count()):
		var surface = csgMesh[-1].surface_get_arrays(t)
		var verts = surface[0]
		var UVs = surface[4]
		var normals = surface[1]
		var mat:SpatialMaterial = csgMesh[-1].surface_get_material(t)
		var faces = []
		
		#create_faces_from_verts (Triangles)
		var tempv=0
		for v in range(verts.size()):
			if tempv%3==0:
				faces.append([])
			faces[-1].append(v+1)
			tempv+=1
			tempv= tempv%3
		
		#add verticies
		var tempvcount =0
		for ver in verts:
			objcont+=str("v ",ver[0],' ',ver[1],' ',ver[2])+"\n"
			tempvcount +=1
			
		#add UVs
		for uv in UVs:
			objcont+=str("vt ",uv[0],' ',uv[1])+"\n"
		for norm in normals:
			objcont+=str("vn ",norm[0],' ',norm[1],' ',norm[2])+"\n"
		
		#add groups and materials
		objcont+="g surface"+str(t)+"\n"
		
		if mat == null:
			mat = blank_material
		
		objcont+="usemtl "+str(mat)+"\n"
		
		#add faces
		for face in faces:
			objcont+=str("f ", face[2]+vertcount,"/",face[2]+vertcount,"/",face[2]+vertcount,
			' ',face[1]+vertcount,"/",face[1]+vertcount,"/",face[1]+vertcount,
			' ',face[0]+vertcount,"/",face[0]+vertcount,"/",face[0]+vertcount)+"\n"
		#update verts
		vertcount+=tempvcount
		
		#create Materials for current surface
		matcont+=str("newmtl "+str(mat))+'\n'
		matcont+=str("Kd ",mat.albedo_color.r," ",mat.albedo_color.g," ",mat.albedo_color.b)+'\n'
		matcont+=str("Ke ",mat.emission.r," ",mat.emission.g," ",mat.emission.b)+'\n'
		matcont+=str("d ",mat.albedo_color.a)+"\n"
		

	
	var path = 'exports'
	
	var objfile = File.new()
	objfile.open(path+"/"+object_name+".obj", File.WRITE)
	objfile.store_string(objcont)
	objfile.close()

	var mtlfile = File.new()
	mtlfile.open(path+"/"+object_name+".mtl", File.WRITE)
	mtlfile.store_string(matcont)
	mtlfile.close()

	#output message
	print("CSG Mesh Exported")

		
