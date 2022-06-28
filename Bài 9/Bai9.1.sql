use master
go

if exists(select 'True' from master.dbo.sysdatabases where name = 'QLBanHang')
	drop database QLBanHang
go

create database QLBanHang 
go

use QLBanHang
go

create table HangSX(
	MaHangSX nchar(10) primary key,
	TenHang nvarchar(20),
	DiaChi nvarchar(30),
	SoDT nvarchar(20),
	Email nvarchar(30)
)
go

create table SanPham(
	MaSP nchar(10) primary key,
	MaHangSX nchar(10),
	TenSP nvarchar(20),
	SoLuong int,
	MauSac nvarchar(20),
	GiaBan money,
	DonViTinh nchar(10),
	MoTa nvarchar(max)

	constraint FK_MaHangSX foreign key(MaHangSX) references HangSX(MaHangSX)
)
go

create table NhanVien(
	MaNV nchar(10) primary key,
	TenNV nvarchar(20),
	GioiTinh nchar(10),
	DiaChi nvarchar(30),
	SoDT nvarchar(20),
	Email nvarchar(30),
	TenPhong nvarchar(30)
)
go

create table PNhap(
	SoHDN nchar(10) primary key,
	NgayNhap date,
	MaNV nchar(10)

	constraint FK_MaNV foreign key(MaNV) references NhanVien(MaNV)
)
go

create table Nhap(
	SoHDN nchar(10),
	MaSP nchar(10),
	SoLuongN int,
	DonGiaN money

	constraint PK_SoHDN_MaSP primary key(SoHDN, MaSP),
	constraint FK_MaSP foreign key(MaSP) references SanPham(MaSP),
	constraint FK_SoHDN foreign key(SoHDN) references PNhap(SoHDN)
)
go

create table PXuat(
	SoHDX nchar(10) primary key,
	NgayXuat date,
	MaNV nchar(10)

	constraint FK_MaNV_1 foreign key(MaNV) references NhanVien(MaNV)
)
go

create table Xuat(
	SoHDX nchar(10),
	MaSP nchar(10),
	SoLuongX int

	constraint PK_SoHDX_MaSP primary key(SoHDX, MaSP),
	constraint FK_MaSP_1 foreign key(MaSP) references SanPham(MaSP),
	constraint FK_SoHDX foreign key(SoHDX) references PXuat(SoHDX)
)
go

insert into HangSX values(N'H01', N'Samsung', N'Korea', N'011-08271717', N'ss@gmail.com.kr')
insert into HangSX values(N'H02', N'OPPO', N'China', N'081-08626262', N'oppo@gmail.com.cn')
insert into HangSX values(N'H03', N'Vinfone', N'Việt nam', N'084-098262626', N'vf@gmail.com.vn')
select * from HangSX
go

insert into NhanVien values(N'NV01',N'Nguyễn Thị Thu',N'Nữ',N'Hà Nội',N'0982626521',N'thu@gmail.com',N'Kế toán')
insert into NhanVien values(N'NV02',N'Lê Văn Nam',N'Nam',N'Bắc Ninh',N'0972525252',N'nam@gmail.com',N'Vật tư')
insert into NhanVien values(N'NV03',N'Trần Hòa Bình',N'Nữ',N'Hà Nội',N'0328388388',N'hb@gmail.com',N'Kế toán')
select * from NhanVien
go

insert into SanPham values(N'SP01', N'H02', N'F1 Plus', 100, N'Xám', 7000000, N'Chiếc', N'Hàng cận cao cấp')
insert into SanPham values(N'SP02', N'H01', N'Galaxy Note11', 50, N'Đỏ', 19000000, N'Chiếc', N'Hàng cao cấp')
insert into SanPham values(N'SP03', N'H02', N'F3 lite', 200, N'Nâu', 3000000, N'Chiếc', N'Hàng phổ thông')
insert into SanPham values(N'SP04', N'H03', N'Vjoy3', 200, N'Xám', 1500000, N'Chiếc', N'Hàng phổ thông')
insert into SanPham values(N'SP05', N'H01', N'Galaxy V21', 500, N'Nâu', 8000000, N'Chiếc', N'Hàng cận cao cấp')
select * from SanPham
go

insert into PNhap values(N'N01', '2019-2-5', N'NV01')
insert into PNhap values(N'N02', '2020-4-7', N'NV02')
insert into PNhap values(N'N03', '2019-5-17', N'NV02')
insert into PNhap values(N'N04', '2019-3-22', N'NV03')
insert into PNhap values(N'N05', '2019-7-7', N'NV01')
select * from PNhap
go

insert into Nhap values(N'N01', N'SP02', 10, 17000000)
insert into Nhap values(N'N02', N'SP01', 30,  6000000)
insert into Nhap values(N'N03', N'SP04', 20, 1200000)
insert into Nhap values(N'N04', N'SP01', 10, 6200000)
insert into Nhap values(N'N05', N'SP05', 20, 7000000)
select * from Nhap
go

insert into PXuat values(N'X01', '2020-6-14', N'NV02')
insert into PXuat values(N'X02', '2019-3-5', N'NV03')
insert into PXuat values(N'X03', '2019-12-12', N'NV01')
insert into PXuat values(N'X04', '2019-6-2', N'NV02')
insert into PXuat values(N'X05', '2019-5-18', N'NV01')
select * from PXuat
go

insert into Xuat values(N'X01', N'SP03', 5)
insert into Xuat values(N'X02', N'SP01', 3)
insert into Xuat values(N'X03', N'SP02', 1)
insert into Xuat values(N'X04', N'SP03', 2)
insert into Xuat values(N'X05', N'SP05', 1)
select * from Xuat
go

-- Tạo thủ tục nhập liệu cho bảng HangSX, với các tham biến truyền vào MaHangSX, 
-- TenHang, DiaChi, SoDT, Email. Hãy kiểm tra xem TenHang đã tồn tại trước đó hay chưa? 
-- Nếu có rồi thì không cho nhập và Đưa ra thông báo.

create procedure Cau1(@MaHangSX nchar(10),
						@TenHang nvarchar(20), 
						@DiaChi nvarchar(30),
						@SoDT nvarchar(20), 
						@Email nvarchar(30))
as 
	begin
		if(exists(select * from HangSX where TenHang = @TenHang))
			print N'Đã tồn tại tên hãng ' + @TenHang + N' trong cơ sở dữ liệu'
		else 
			insert into HangSX values(@MaHangSX, @TenHang, @DiaChi, @SoDT, @Email)
	end
go

execute Cau1 N'H05', N'VinSmart', N'Việt Nam', N'1234567890', N'vinsmart@gmail.com'
go

select * from HangSX
go

-- Tạo thủ tục nhập dữ liệu cho bảng sản phẩm với các tham biến truyền vào MaSP, 
-- TenHangSX, TenSP, SoLuong, MauSac, GiaBan, DonViTinh, MoTa. Hãy kiểm tra xem 
-- nếu MaSP đã tồn tại thì cập nhật thông tin sản phẩm theo mã, ngược lại thêm mới sản phẩm vào bảng SanPham.

create proc Cau2(@MaSP nchar(10),
					@MaHangSX nchar(10),
					@TenSP nvarchar(20), 
					@SoLuong int,
					@MauSac nvarchar(20),
					@GiaBan money,
					@DonViTInh nchar(10),
					@MoTa nvarchar(max))
as
	begin
		if(exists(select * from SanPham where MaSP = @MaSP))
			update SanPham
			set TenSP = @TenSP, SoLuong = @SoLuong, MauSac = @MauSac, GiaBan = @GiaBan, DonViTinh = @DonViTInh, MoTa = @MoTa
			where MaSP = @MaSP
		else 
			insert into SanPham values(@MaSP, @MaHangSX, @TenSP, @SoLuong, @MauSac, @GiaBan, @DonViTinh, @MoTa)
	end
go

select * from SanPham
go

execute Cau2 N'SP06', N'H04', N'V3', 500, N'Đen', 10000000, N'Chiếc', N'Hàng cao cấp'
go

select * from SanPham
go

-- Viết thủ tục xóa dữ liệu bảng HangSX với tham biến là TenHang. Nếu TenHang chưa 
-- có thì thông báo, ngược lại xóa HangSX với hãng bị xóa là TenHang. (Lưu ý: xóa HangSX
-- thì phải xóa các sản phẩm mà HangSX này cung ứng). 

create proc Cau3(@TenHang nvarchar(20))
as 
	begin
		if(not exists(select * from HangSX where TenHang = @TenHang))
			print N'Không tồn tại tên hãng ' + @TenHang + N' trong cơ sở dữ liệu'
		else 
			begin
				declare @MaHangSX nchar(10)
				set @MaHangSX = (select MaHangSX from HangSX where TenHang = @TenHang)
				delete from SanPham where MaHangSX = @MaHangSX
				delete from HangSX  where MaHangSX = @MaHangSX 
			end
	end
go

select * from SanPham
go

execute Cau3 N'VinSmart'
go

select * from SanPham
go

--d. Viết thủ tục nhập dữ liệu cho bảng nhân viên với các tham biến manv, TenNV, GioiTinh, 
--DiaChi, SoDT, Email, Phong, và 1 biến cờ Flag, Nếu Flag = 0 thì cập nhật dữ liệu cho bảng 
--nhân viên theo manv, ngược lại thêm mới nhân viên này.

create procedure CauD(@MaNV nchar(10),
					  @TenNV nvarchar(20),
					  @GioiTinh nchar(10),
					  @DiaChi nvarchar(30),
					  @SoDT nvarchar(20),
					  @Email nvarchar(30),
					  @TenPhong nvarchar(30),
					  @Flag int)
as
	begin
		if(@Flag = 0)
			begin
				update NhanVien
				set TenNV = @TenNV, GioiTinh = @GioiTinh, DiaChi = @DiaChi,
					SoDT = @SoDT, Email = @Email, TenPhong = @TenPhong
				where MaNV = @MaNV
			end
		else
			begin
				insert into NhanVien values(@MaNV, @TenNV, @GioiTinh, @DiaChi, @SoDT, @Email, @TenPhong)
			end
	end
go

execute CauD N'NV04',N'Nguyễn Nhật Minh',N'Nam',N'Thanh Hóa',N'0332803583',N'fcarsenal614@gmail.com',N'Công Nghệ Thông Tin', 1
select * from NhanVien
go

--e. Viết thủ tục nhập dữ liệu cho bảng Nhap với các tham biến SoHDN, MaSP, manv, 
--NgayNhap, SoLuongN, DonGiaN. Kiểm tra xem MaSP có tồn tại trong bảng SanPham hay 
--không? manv có tồn tại trong bảng NhanVien hay không? Nếu không thì thông báo, ngược 
--lại thì hãy kiểm tra: Nếu SoHDN đã tồn tại thì cập nhật bảng Nhap theo SoHDN, ngược lại 
--thêm mới bảng Nhap.

create procedure CauE(@SoHDN nchar(10),
					  @MaSP nchar(10),
					  @MaNV nchar(10),
					  @NgayNhap date,
					  @SoLuongN int,
					  @DonGiaN money)
as
	begin
		if(not exists(select * from SanPham where MaSP = @MaSP))
			begin
				print N'Không tồn tại Mã Sản Phẩm ' + @MaSP + ' trong cơ sở dữ liệu'
			end
		else
			if(not exists(select * from NhanVien where MaNV = @MaNV))
				begin
					print N'Không tồn tại Mã Nhân Viên ' + @MaNV + ' trong cơ sở dữ liệu'
				end
			else
				if(exists(select * from Nhap where SoHDN = @SoHDN))
					begin
						update Nhap
						set MaSP = @MaSP,
							SoLuongN = @SoLuongN,
							DonGiaN = @DonGiaN
						where SoHDN = @SoHDN
					end
				else
					begin
						insert into Nhap values(@SoHDN, @MaSP, @SoLuongN, @DonGiaN)
					end
	end
go

execute CauE N'N04', N'SP01', N'NV02', '2021-4-19', 10, 6200000
select * from Nhap
select * from PNhap
go

--f. Viết thủ tục nhập dữ liệu cho bảng xuat với các tham biến SoHDX, MaSP, manv, 
--NgayXuat, SoLuongX. Kiểm tra xem MaSP có tồn tại trong bảng SanPham hay không? 
--manv có tồn tại trong bảng NhanVien hay không? SoLuongX <= SoLuong? Nếu không thì 
--thông báo, ngược lại thì hãy kiểm tra: Nếu SoHDX đã tồn tại thì cập nhật bảng Xuat theo 
--SoHDX, ngược lại thêm mới bảng Xuat.

create procedure CauF(@SoHDX nchar(10),
					  @MaSP nchar(10),
					  @MaNV nchar(10),
					  @NgayXuat date,
					  @SoLuongX int) 
as
	begin
		if(not exists(select * from SanPham where MaSP = @MaSP))
			begin
				print N'Không tồn tại ' + @MaSP + ' trong cơ sở dữ liệu'
			end
		else
			if(not exists(select * from NhanVien where MaNV = @MaNV))
				begin
					print N'Không tồn tại ' + @MaNV + ' trong cơ sở dữ liệu'
				end
			else
				begin
					declare @SoLuong int
					set @SoLuong = (select SoLuong from SanPham where MaSP = @MaSP)
					
					if(@SoLuongX <= @SoLuong)
						begin
							if(exists(select * from PXuat where SoHDX = @SoHDX))
								begin
									update PXuat
									set NgayXuat = @NgayXuat, MaNV = @MaNV
									where SoHDX = @SoHDX
								end
							else
								begin
									insert into PXuat values(@SoHDX, @NgayXuat, @MaNV)
								end
						end
					else
						begin
							print N'Số lượng xuất vượt quá số lượng có trong kho'
						end
				end
	end
go

execute CauF N'X06', N'SP01', N'NV01', '2021-3-31', 10
select * from PXuat
go

--g. Viết thủ tục xóa dữ liệu bảng NhanVien với tham biến là manv. Nếu manv chưa có thì 
--thông báo, ngược lại xóa NhanVien với NhanVien bị xóa là manv. (Lưu ý: xóa NhanVien
--thì phải xóa các bảng Nhap, Xuat mà nhân viên này tham gia).
create procedure CauG(@MaNV nchar(10))
as
	begin
		if(not exists(select * from NhanVien where MaNV = @MaNV))
			begin
				print N'Nhân Viên có mã ' + @MaNV + ' không tồn tại trong bảng Nhân Viên'
			end
		else
			begin
				delete from Nhap where SoHDN in (select SoHDN from PNhap where MaNV = @MaNV)
				delete from Xuat where SoHDX in (select SoHDX from PXuat where MaNV = @MaNV)
				delete from PNhap where MaNV = @MaNV
				delete from PXuat where MaNV = @MaNV
				delete from NhanVien where MaNV = @MaNV
			end
	end
go

select * from PNhap
select * from PXuat 
select * from Nhap
select * from Xuat
select * from NhanVien
go
--TH có tồn tại
execute CauG N'NV03'
go
--TH không tồn tại
execute CauG N'NV04'
go 
--h. Viết thủ tục xóa dữ liệu bảng SanPham với tham biến là MaSP. Nếu MaSP chưa có thì 
--thông báo, ngược lại xóa SanPham với SanPham bị xóa là MaSP. (Lưu ý: xóa SanPham
--thì phải xóa các bảng Nhap, Xuat mà SanPham này cung ứng).

create procedure CauH(@MaSP nchar(10))
as
	begin
		if(not exists(select * from SanPham where MaSP = @MaSP))
			begin
				print N'Không tồn tại Sản Phẩm có Mã ' + @MaSP
			end
		else
			begin
				delete from Nhap where MaSP = @MaSP
				delete from Xuat where MaSP = @MaSP
				delete from SanPham where MaSP = @MaSP
			end
	end
go

execute CauH N'SP01'
go

backup database QLBanHang to disk = 'D:\QLBH.bak'
go