const Tile = ({ title, description, link }) => {
    return (
        <a class="no-underline hover:no-underline" href={link}>
            <div className="hover:cursor-pointer hover:scale-105 transition-all text-black border border-solid border-gray-300 p-5 m-2 text-center rounded-lg shadow-md" >
                <h3>{title}</h3>
                <p>{description}</p>
            </div>
        </a>
    );
};

export default Tile;
